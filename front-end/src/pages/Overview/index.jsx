import React, { useEffect, useState } from 'react';
import { getUserClassFromCookies, setUserClassInCookies, getUserNameFromCookies } from '../../functions/cookiesManager';
import Styles from "./overview.module.css";
import { useNavigate } from "react-router-dom";
import ChangeNameFacction from "../../components/OverviewCommands/changeFacctionName"
import ChangeLeder from "../../components/OverviewCommands/changeLeader"
import AddCommunity from "../../components/OverviewCommands/addComunity"
import RemoveNation from "../../components/OverviewCommands/removeNation"


const Overview = () => {
    const [userClass, setUserClass] = useState('');
    const navigate = useNavigate();
    useEffect(() => {
        const uClass = getUserClassFromCookies()
        setUserClass(uClass);

        switch (uClass) {
            case "Comandante":
                console.log("Comandante");
                break;
            case "Oficial":
                console.log("Oficial");
                break;
            case "Lider":
                console.log("Lider");
                break;
            case "Cientista":
                console.log("Cientista");
                break;
            default:
                navigate('/');
                console.log("Erro");
        }
    }, []);

    const handleLogoff = () => {
        setUserClassInCookies("");
        navigate('/');
    };

    const leaderDashboard = ()=>(
        <>
            <div className={Styles.grupo}>
                <div className={Styles.conteudo}>
                    <ChangeNameFacction nome="faccao" acao={()=>{}}/>
                </div>
                <div className={Styles.conteudo}>
                    <AddCommunity/>                    
                </div>
            </div>

            <div className={Styles.conteudo}>
                <ChangeLeder/>
            </div>

            <div className={Styles.conteudo}>
                <RemoveNation/>
            </div>
        </>
    );

    const commanderDashboard = ()=>(
        <>
            <div className={Styles.grupo}>
                <div className={Styles.conteudo}>
                    <ChangeNameFacction nome="faccao" acao={()=>{}}/>
                </div>
                <div className={Styles.conteudo}>
                    <AddCommunity/>                    
                </div>
            </div>

            <div className={Styles.conteudo}>
                <ChangeLeder/>
            </div>

            <div className={Styles.conteudo}>
                <RemoveNation/>
            </div>
        </>
    );

    return (
        <div className={Styles.container}>
            <div className={Styles.user}>
                <h2>Bem-vindo, {userClass === "cientista" ? "Dr(a)" : userClass} {getUserNameFromCookies()}</h2>
                <div className={Styles.actions}>
                    <button >Ver Relatórios</button>
                    <button onClick={handleLogoff}>Logoff</button>
                </div>
            </div>
            <div className={Styles.dashboard}>
                {userClass === "Lider" && leaderDashboard()}
                {userClass === "Comandante" && commanderDashboard()}
            </div>



        </div>
    );
};

export default Overview;